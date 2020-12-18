const res_name = GetParentResourceName()

$(document).ready(function() 
{
    // Register frames here to call NUI events on them
    const frames = {}
    let z = 10

    // Listen for NUI events
    window.addEventListener('message', function(event)
    {
        const iframe = $(`#FRAME_${event.data.name}`);
        const event_name = event.data.nui_event;
        delete event.data.nui_event;

        if (event_name == "ui/hide" && iframe != null)
        {
            iframe.hide()
            EventCalled('Hide', null, event.data.name);
        }
        else if (event_name == "ui/show")
        {
            iframe.show()
            EventCalled('Show', null, event.data.name);
        }
        else if (event_name == "ui/event")
        {
            const nui_event = event.data.data.nui_event;
            delete event.data.data.nui_event;
            EventCalled(nui_event, event.data.data, event.data.name);
        }
        else if (event_name == "ui/create")
        {
            const iframe_new = $(`<iframe id='FRAME_${event.data.name}' allowtransparency="true" scrolling="no" name="${event.data.name}" src="../../../${event.data.path}"></iframe>`)
            
            Object.keys(event.data.css).forEach((key, index) => 
            {
                iframe_new.css(key, event.data.css[key]);
            })

            $('body').append(iframe_new)
            frames[event.data.name] = iframe_new
            z++;

            if (!event.data.visible)
            {
                iframe_new.hide()
            }

            iframe_new[0].contentWindow.onkeyup = (e) => {OnKey(e, 'keyup')}
            iframe_new[0].contentWindow.onkeydown = (e) => {OnKey(e, 'keydown')}
            iframe_new[0].contentWindow.onkeypress = (e) => {OnKey(e, 'keypress')}
            iframe_new[0].contentWindow.OOF = new OOF(event.data.name);
        }
        else if (event_name == "ui/remove" && frames[event.data.name] != null)
        {
            frames[event.data.name].remove()
            delete frames[event.data.name]
        }
        else if (event_name == "ui/bring_to_front" && frames[event.data.name] != null)
        {
            frames[event.data.name].css('z-index', z++)
        }
        else if (event_name == "ui/send_to_back" && frames[event.data.name] != null)
        {
            frames[event.data.name].css('z-index', 0)
        }
        else if (event_name == "ui/lua_ready")
        {
            $.post(`http://${res_name}/ui/ready`, 
                JSON.stringify({size: {x: $(window).width(), y: $(window).height()}}));
        }
    })

    function EventCalled(event_name, data, ui_name)
    {
        if (events[event_name] != null)
        {
            events[event_name].forEach((entry) => 
            {
                if (entry.callback != null && (ui_name == null || ui_name == entry.name))
                {
                    entry.callback(data);
                }
            })
        }
    }

    const events = {};

    // Additional OOF functions
    class OOF 
    {
        constructor (name)
        {
            this.name = name
        }

        GetFocus(elem)
        {
            elem.focus();
        }

        CallEvent(event_name, args)
        {
            if (event_name == null || event_name.length == 0)
            {
                this.console.error(`Cannot CallEvent without a valid event_name`)
                return;
            }
            args = args || {}
            args = JSON.stringify(args)

            $.post(`http://${res_name}/${this.name}_${event_name}`, args);
        }

        Subscribe(event_name, callback)
        {
            if (events[event_name] == null)
            {
                events[event_name] = []
            }
            events[event_name].push({callback: callback, name: this.name});
        }
    }

    const key_types = 
    {
        'keyup': 'KeyUp',
        'keydown': 'KeyDown',
        'keypress': 'KeyPress',
    }
    function OnKey(e, type)
    {
        const keycode = (typeof e.which === 'number') ? e.which : e.keyCode;

        $.post(`http://${res_name}/ui/keypress`, JSON.stringify({key: keycode, type: type}));

        const returns = []

        const event_name = key_types[type];
        if (events[event_name] != null)
        {
            events[event_name].forEach((entry) => 
            {
                returns.push(entry.callback({key: keycode, event: e}));
            })
        }

        returns.forEach((return_val) => 
        {
            if (return_val != undefined)
            {
                return return_val;
            }
        })

    }

    document.onkeyup = (e) => {OnKey(e, 'keyup');}
    document.onkeydown = (e) => {OnKey(e, 'keydown');}
    document.onkeypress = (e) => {OnKey(e, 'keypress');}
    
})
